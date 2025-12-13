/**
 * Category Service - Handles category management and auto-categorization
 */

import { v4 as uuidv4 } from 'uuid';
import { databaseService } from '../database/DatabaseService';
import type { Category } from '../../models/Category';
import { DEFAULT_CATEGORIES } from '../../models/Category';

export interface ICategoryService {
  getAllCategories(): Promise<Category[]>;
  getCategoryById(id: string): Promise<Category | null>;
  createCategory(name: string, keywords: string[], color?: string): Promise<Category>;
  updateCategory(id: string, updates: Partial<Category>): Promise<Category>;
  deleteCategory(id: string): Promise<void>;
  categorizeLog(content: string): Promise<string | null>;
  initializeDefaultCategories(): Promise<void>;
}

class CategoryService implements ICategoryService {
  async getAllCategories(): Promise<Category[]> {
    const results = await databaseService.executeSql(
      'SELECT * FROM categories ORDER BY is_system DESC, name ASC'
    );

    return results.map((row) => this.mapRowToCategory(row));
  }

  async getCategoryById(id: string): Promise<Category | null> {
    const results = await databaseService.executeSql(
      'SELECT * FROM categories WHERE id = ?',
      [id]
    );

    if (results.length === 0) return null;

    return this.mapRowToCategory(results[0]);
  }

  async createCategory(
    name: string,
    keywords: string[],
    color?: string
  ): Promise<Category> {
    const now = Date.now();
    const category: Category = {
      id: uuidv4(),
      name,
      color,
      keywords,
      isSystem: false,
      createdAt: now,
      updatedAt: now,
    };

    await databaseService.executeSql(
      `INSERT INTO categories (
        id, name, color, keywords, parent_category, is_system, created_at, updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        category.id,
        category.name,
        category.color || null,
        JSON.stringify(category.keywords),
        category.parentCategory || null,
        category.isSystem ? 1 : 0,
        category.createdAt,
        category.updatedAt,
      ]
    );

    return category;
  }

  async updateCategory(id: string, updates: Partial<Category>): Promise<Category> {
    const now = Date.now();
    const updateFields: string[] = [];
    const params: any[] = [];

    if (updates.name !== undefined) {
      updateFields.push('name = ?');
      params.push(updates.name);
    }
    if (updates.color !== undefined) {
      updateFields.push('color = ?');
      params.push(updates.color);
    }
    if (updates.keywords !== undefined) {
      updateFields.push('keywords = ?');
      params.push(JSON.stringify(updates.keywords));
    }

    updateFields.push('updated_at = ?');
    params.push(now);
    params.push(id);

    await databaseService.executeSql(
      `UPDATE categories SET ${updateFields.join(', ')} WHERE id = ?`,
      params
    );

    const category = await this.getCategoryById(id);
    if (!category) throw new Error('Category not found after update');

    return category;
  }

  async deleteCategory(id: string): Promise<void> {
    // Don't allow deleting system categories
    const category = await this.getCategoryById(id);
    if (category?.isSystem) {
      throw new Error('Cannot delete system category');
    }

    await databaseService.executeSql('DELETE FROM categories WHERE id = ?', [id]);
  }

  async categorizeLog(content: string): Promise<string | null> {
    const categories = await this.getAllCategories();
    const lowerContent = content.toLowerCase();

    // Find category with matching keywords
    for (const category of categories) {
      for (const keyword of category.keywords) {
        if (lowerContent.includes(keyword.toLowerCase())) {
          return category.name;
        }
      }
    }

    return null;
  }

  async initializeDefaultCategories(): Promise<void> {
    const existingCategories = await this.getAllCategories();

    // Only initialize if no categories exist
    if (existingCategories.length > 0) {
      return;
    }

    const now = Date.now();
    const statements = DEFAULT_CATEGORIES.map((cat) => ({
      sql: `INSERT INTO categories (
        id, name, color, keywords, parent_category, is_system, created_at, updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      params: [
        cat.id,
        cat.name,
        cat.color || null,
        JSON.stringify(cat.keywords),
        cat.parentCategory || null,
        cat.isSystem ? 1 : 0,
        now,
        now,
      ],
    }));

    await databaseService.transaction(statements);
  }

  private mapRowToCategory(row: any): Category {
    return {
      id: row.id,
      name: row.name,
      color: row.color || undefined,
      keywords: JSON.parse(row.keywords),
      parentCategory: row.parent_category || undefined,
      isSystem: row.is_system === 1,
      createdAt: row.created_at,
      updatedAt: row.updated_at,
    };
  }
}

export const categoryService = new CategoryService();
